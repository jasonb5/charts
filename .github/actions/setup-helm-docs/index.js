const core = require('@actions/core');
const tc = require('@actions/tool-cache');

const downloadTool = async () => {
	let cachedPath = tc.find('helm-docs', '1.11.3');

	if (cachedPath === "") {
		const helmDocsPath = await tc.downloadTool('https://github.com/norwoodj/helm-docs/releases/download/v1.11.3/helm-docs_1.11.3_Linux_x86_64.tar.gz');
		const helmDocsExtractedPath = await tc.extractTar(helmDocsPath);
		cachedPath = await tc.cacheDir(helmDocsExtractedPath, 'helm-docs', '1.11.3');
	}
	
	core.addPath(cachedPath);
};

downloadTool();
