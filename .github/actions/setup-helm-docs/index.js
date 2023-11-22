const core = require('@actions/core');
const tc = require('@actions/tool-cache');

const downloadTool = async () => {
	const cachedPath = tc.find('helm-docs', '1.11.3');

	if (helmDocsPath === nil) {
		const helmDocsPath = await tc.downloadTool('https://github.com/norwoodj/helm-docs/releases/download/v1.11.3/helm-docs_1.11.3_Linux_x86_64.tar.gz');
		const helmDocsExtractedPath = await tc.extractTar(helmDocsPath);
		const cachedPath = await tc.cacheDir(helmDocsExtractedPath, 'helm-docs', '1.11.3');
	}
	core.addPath(cachedPath);
};

downloadTool();
