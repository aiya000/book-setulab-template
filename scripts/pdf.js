const puppeteer = require('puppeteer');

const outputPath = process.argv[2];
const url = process.argv[3];
const pageFormat = process.argv[4];
const waitFor = process.argv[5];  // milliseconds
if (process.argv.length != 6) {
  console.log('Please specified command options. `node pdf.js <output-path> <vivliostyle-url> <page-format> <time-to-render>`');
  process.exit(1);
}

console.log(`Using ${pageFormat}`);

(async () => {
  try {
    const browser = await puppeteer.launch({ args: ['--no-sandbox'] });
    const page = await browser.newPage();
    await page.goto(url, { waitUntil: 'networkidle0' });

    console.log(`Please wait for ${waitFor}ms...`);
    await page.waitFor(parseInt(waitFor, 10));
    await page.pdf(makeOptionForB5OrAnother(pageFormat));

    await browser.close();
    console.log(`Output: ${outputPath}`);
  } catch (e) {
    console.log(`Error! in pdf.js: ${e}`);
  }
})();

function makeOptionForB5OrAnother(pageFormat) {
  return pageFormat === 'B5'
    ? {
      path: outputPath,
      width: '182mm',
      height: '257mm',
      printBackground: true
    }
    : {
      path: outputPath,
      format: pageFormat,
      printBackground: true
    }
  ;
}
