const { generateWebpackConfig, merge } = require('shakapacker')
const rspack = require('@rspack/core')

const options = generateWebpackConfig()

const customConfig = {
  // Отключаем варнинги о превышении размера файлов
  performance: {
    hints: false,
  },
  plugins: [
    new rspack.optimize.LimitChunkCountPlugin({
      maxChunks: 1,
    }),
    new rspack.ProvidePlugin({
      $: ['jquery', 'default'],
      jQuery: ['jquery', 'default'],
    }),
  ],
  module: {
    rules: [
      {
        test: /\.erb$/,
        enforce: 'pre',
        exclude: /node_modules/,
        use: [
          {
            loader: 'rails-erb-loader',
            options: {
              runner: `${
                /^win/.test(process.platform) ? 'ruby ' : ''
              } bin/rails runner`,
            },
          },
        ],
      },
    ],
  },
}

module.exports = merge(options, customConfig)
