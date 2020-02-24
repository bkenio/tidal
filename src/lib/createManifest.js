const fs = require('fs');
const path = require('path');

module.exports = ({ transcodedLocalPath }) => {
  const manifestPath = path.resolve(`${transcodedLocalPath}/manifest.txt`);
  const transcodedPaths = fs.readdirSync(transcodedLocalPath);
  const manifest = fs.createWriteStream(manifestPath, {
    flags: 'a',
  });

  for (const partName of transcodedPaths) {
    manifest.write(`file './${partName}'\n`);
  }

  manifest.end();
  return manifestPath;
};