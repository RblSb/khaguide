let project = new Project("Empty"); // instance the project

project.addSources('Sources'); // add a source code path
project.addAssets('Assets/**'); // add an asset path

resolve(project);
