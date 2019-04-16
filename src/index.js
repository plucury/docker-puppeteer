'use strict'

const express = require('express')
var fs = require('fs')
var path = require('path')
var multer = require('multer')
const createRenderer = require('./renderer')

const port = process.env.PORT || 3000
const upload = multer({
  storage: multer.diskStorage({
    destination: function(req, file, cb) {
      cb(null, 'tmp')
    },
    filename: function(req, file, cb) {
      cb(null, Date.now() + '-' + randomSuffix(8) + '.html')
    },
  }),
  fileFilter: function(req, file, callback) {
    var ext = path.extname(file.originalname)
    if (ext !== '.html') {
      return callback(new Error('Only html are allowed.'))
    }
    callback(null, true)
  },
})
const app = express()

let renderer = null

// Configure.
app.disable('x-powered-by')


app.use(upload.single('html'), async (req, res, next) => {

  if (req.path === '/health_check') {
    return res.status(200).send('OK')
  }

  let url, outputType, options
  if (req.method == 'GET') {
    ;({ url, outputType, ...options } = req.query)
    if (!url) {
      return res.status(400).send('Search with url parameter. For eaxample, ?url=http://yourdomain')
    }

    if (!url.includes('://')) {
      url = `http://${url}`
    }
  } else if (req.method == 'POST') {
    if (!req.file) {
      return res.status(400).send('You must upload a file!')
    }
    ;({ outputType, ...options } = req.body)
    url = 'file://' + path.resolve(req.file.path)
  }

  console.log(url, outputType)

  if (!outputType) {
    return res.status(400).send('Unkonwn outputType.')
  }

  try {
    switch (outputType) {
      case 'pdf':
        const pdf = await renderer.pdf(url, options)
        res.set('Content-type', 'application/pdf').send(pdf)
        break

      case 'screenshot':
        let contentType = 'image/png'
        if (options.type && options.type === 'jpeg') {
          contentType = 'image/jpeg'
        }
        const image = await renderer.screenshot(url, options)
        res.set('Content-type', contentType).send(image)
        break

      default:
        const html = await renderer.render(url, options)
        res.status(200).send(html)
    }
    if (req.file) {
      fs.unlinkSync(req.file.path)
    }
  } catch (e) {
    next(e)
  }
})

// Error page.
app.use((err, req, res, next) => {
  console.error(err)
  res.status(500).send('Oops, An expected error seems to have occurred.')
})

function randomSuffix(length) {
  let text = ''
  let possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'

  for (let i = 0; i < length; i++)
    text += possible.charAt(Math.floor(Math.random() * possible.length))

  return text
}

// Create renderer and start server.
createRenderer()
  .then(createdRenderer => {
    renderer = createdRenderer
    console.info('Initialized renderer.')

    app.listen(port, () => {
      console.info(`Listen port on ${port}.`)
    })
  })
  .catch(e => {
    console.error('Fail to initialze renderer.', e)
  })

// Terminate process
process.on('SIGINT', () => {
  process.exit(0)
})
