Inventory = new Mongo.Collection("inventory");
Items = new Mongo.Collection("items");
Session.setDefault("selected", []);
Session.setDefault("type", "");

