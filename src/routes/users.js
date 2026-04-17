import { Router } from 'express';

const router = Router();

// In-memory store (intentionally simple — no DB needed for CI/CD demo)
let users = [
  { id: 1, name: 'Alice',   role: 'admin'     },
  { id: 2, name: 'Bob',     role: 'developer' },
  { id: 3, name: 'Charlie', role: 'viewer'    },
];

// GET /api/users
router.get('/', (req, res) => {
  res.status(200).json({ success: true, count: users.length, data: users });
});

// GET /api/users/:id
router.get('/:id', (req, res) => {
  const user = users.find(u => u.id === parseInt(req.params.id));
  if (!user) return res.status(404).json({ success: false, error: 'User not found' });
  res.status(200).json({ success: true, data: user });
});

// POST /api/users
router.post('/', (req, res) => {
  const { name, role } = req.body;

  if (!name || !role) {
    return res.status(400).json({ success: false, error: 'Name and role are required' });
  }

  const newUser = { id: users.length + 1, name, role };
  users.push(newUser);
  res.status(201).json({ success: true, data: newUser });
});

// DELETE /api/users/:id
router.delete('/:id', (req, res) => {
  const idx = users.findIndex(u => u.id === parseInt(req.params.id));
  if (idx === -1) return res.status(404).json({ success: false, error: 'User not found' });

  const deleted = users.splice(idx, 1);
  res.status(200).json({ success: true, data: deleted[0] });
});

export default router;