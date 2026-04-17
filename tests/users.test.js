import request from 'supertest';
import app from '../src/app.js';

describe('Users API', () => {

  // ── GET /api/users ──────────────────────────────────────────
  describe('GET /api/users', () => {
    it('should return 200 with list of users', async () => {
      const res = await request(app).get('/api/users');

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(Array.isArray(res.body.data)).toBe(true);
    });

    it('should return a count field', async () => {
      const res = await request(app).get('/api/users');

      expect(typeof res.body.count).toBe('number');
    });

    it('should return users with id, name, and role fields', async () => {
      const res = await request(app).get('/api/users');
      const user = res.body.data[0];

      expect(user).toHaveProperty('id');
      expect(user).toHaveProperty('name');
      expect(user).toHaveProperty('role');
    });
  });

  // ── GET /api/users/:id ──────────────────────────────────────
  describe('GET /api/users/:id', () => {
    it('should return a single user by id', async () => {
      const res = await request(app).get('/api/users/1');

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.id).toBe(1);
    });

    it('should return 404 for a non-existent user', async () => {
      const res = await request(app).get('/api/users/999');

      expect(res.statusCode).toBe(404);
      expect(res.body.success).toBe(false);
    });
  });

  // ── POST /api/users ─────────────────────────────────────────
  describe('POST /api/users', () => {
    it('should create a new user', async () => {
      const res = await request(app)
        .post('/api/users')
        .send({ name: 'Diana', role: 'designer' });

      expect(res.statusCode).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data.name).toBe('Diana');
      expect(res.body.data.role).toBe('designer');
    });

    it('should return 400 if name is missing', async () => {
      const res = await request(app)
        .post('/api/users')
        .send({ role: 'designer' });

      expect(res.statusCode).toBe(400);
      expect(res.body.success).toBe(false);
    });

    it('should return 400 if role is missing', async () => {
      const res = await request(app)
        .post('/api/users')
        .send({ name: 'Diana' });

      expect(res.statusCode).toBe(400);
      expect(res.body.success).toBe(false);
    });
  });

  // ── DELETE /api/users/:id ───────────────────────────────────
  describe('DELETE /api/users/:id', () => {
    it('should delete an existing user', async () => {
      const res = await request(app).delete('/api/users/1');

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
    });

    it('should return 404 when deleting a non-existent user', async () => {
      const res = await request(app).delete('/api/users/999');

      expect(res.statusCode).toBe(404);
      expect(res.body.success).toBe(false);
    });
  });

  // ── 404 handler ─────────────────────────────────────────────
  describe('Unknown routes', () => {
    it('should return 404 for unknown routes', async () => {
      const res = await request(app).get('/api/unknown');

      expect(res.statusCode).toBe(404);
    });
  });

});