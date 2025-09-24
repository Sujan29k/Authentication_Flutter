const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const itemController = require('../controllers/itemController');

router.get('/', auth, itemController.getItems);
router.post('/', auth, itemController.addItem);
router.put('/:id', auth, itemController.updateItem);
router.delete('/:id', auth, itemController.deleteItem);

module.exports = router;
