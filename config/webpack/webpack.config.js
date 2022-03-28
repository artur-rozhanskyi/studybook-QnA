const path = require("path");
const webpack = require("webpack");

module.exports = {
  mode: "development",
  optimization: {
    moduleIds: "deterministic",
  },
  entry: {
    application: "./app/javascript/packs/application",
  },
  output: {
    filename: "[name].js",
    sourceMapFilename: "[name].js.map",
    path: path.resolve(__dirname, "..", "..", "app/assets/builds"),
  },
  plugins: [
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1,
    }),
    new webpack.ProvidePlugin({
      $: "jquery",
      jQuery: "jquery",
    }),
  ],
  module: {
    rules: [
      {
        test: /\.erb$/,
        enforce: "pre",
        exclude: /node_modules/,
        use: [
          {
            loader: "rails-erb-loader",
            options: {
              runner: `${
                /^win/.test(process.platform) ? "ruby " : ""
              } bin/rails runner`,
            },
          },
        ],
      },
      {
        test: /\.s[ac]ss$/i,
        use: ["style-loader", "css-loader", "sass-loader"],
      },
      {
        test: /\.css$/i,
        use: ["style-loader", "css-loader"],
      },
    ],
  },
};
