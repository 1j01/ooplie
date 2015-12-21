
module.exports = {
	context: require("path").resolve(__dirname),
	// plugins: [
	// 	new (require("webpack").OldWatchingPlugin)()
	// ],
	entry: "./src/ooplie.coffee",
	output: {
		filename: "ooplie.js"
	},
	module: {
		loaders: [
			{ test: /\.coffee$/, exclude: /node_modules/, loader: "coffee-loader" },
			{ test: /\.(coffee\.md|litcoffee)$/, exclude: /node_modules/, loader: "coffee-loader?literate" }
		]
	},
	resolve: {
		extensions: ["", ".coffee", ".js"]
	}
};
