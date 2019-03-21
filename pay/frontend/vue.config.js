const WebpackShellPlugin = require('webpack-shell-plugin');

module.exports = {
  assetsDir: '',
  configureWebpack: {
    performance: {
        maxAssetSize: 2000000,
    },
    plugins: [
      new WebpackShellPlugin({
        onBuildStart: ['echo Copy'],
        onBuildEnd: ['cp ../static/index.html ../views/layout.etlua']
      })
    ],
  },
}