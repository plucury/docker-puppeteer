'use strict';

const puppeteer = require('puppeteer');

(async() => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.goto('file:///Users/plucury/code/docker-puppeteer/test.html', {waitUntil: 'networkidle2'});
  // page.pdf() is currently supported only in headless mode.
  // @see https://bugs.chromium.org/p/chromium/issues/detail?id=753118
  await page.pdf({
    path: 'hn.pdf',
    format: 'letter'
  });

  await browser.close();
})();