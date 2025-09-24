const Item = require('../models/Item');

exports.getItems = async (req, res) => {
  const items = await Item.find({ user: req.user.id }).sort({ createdAt: -1 });
  res.json(items);
};

exports.addItem = async (req, res) => {
  const item = await Item.create({ title: req.body.title, user: req.user.id });
  res.status(201).json(item);
};

exports.updateItem = async (req, res) => {
  const item = await Item.findOneAndUpdate(
    { _id: req.params.id, user: req.user.id },
    req.body,
    { new: true }
  );
  res.json(item);
};

exports.deleteItem = async (req, res) => {
  await Item.findOneAndDelete({ _id: req.params.id, user: req.user.id });
  res.json({ message: 'Deleted' });
};
