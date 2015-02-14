// package metadata file for Meteor.js
'use strict';

var packageName = 'yury:sortable';  // http://atmospherejs.com/rubaxa/sortable

var packageJson = {version:"1.1.0-yury"} //JSON.parse(Npm.require("fs").readFileSync('package.json'));

Package.describe({
	name: packageName,
	summary: 'Sortable: reactive minimalist reorderable drag-and-drop lists on modern browsers and touch devices',
	version: packageJson.version,
	git: 'https://github.com/RubaXa/Sortable.git',
	readme: 'https://github.com/RubaXa/Sortable/blob/master/meteor/README.md'
});

Package.onUse(function (api) {
	api.versionsFrom(['METEOR@0.9.0', 'METEOR@1.0']);
	api.use('templating', 'client');
	api.use('dburles:mongo-collection-instances@0.2.6');  // to watch collections getting created
	api.export('Sortable');
	api.addFiles([
		'Sortable.js',
		'template.html',  // the HTML comes first, so reactivize.js can refer to the template in it
		'reactivize.js'
	], 'client');
	api.addFiles('methods.js');  // add to both client and server
});

