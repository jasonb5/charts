const core = require('@actions/core');
const github = require('@actions/github');
const tc = require('@actions/tool-cache');

const main = async () => {
	const version = '3.12.3';
	const url = `https://get.helm.sh/helm-v${version}-linux-amd64.tar.gz`;
	const helmPath = await tc.downloadTool(url);
	const helmExtractedFolder = await tc.extractTar(helmPath)
	core.addPath(`${helmExtractedFolder}/linux-amd64`);
};

try {
	main();
} catch (error) {
	core.setFailed(error.message);
}
