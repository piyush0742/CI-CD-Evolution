import request from 'supertest';
import app from '../src/app.js';

describe('GET /api/version', () => {
  it('should return 200 with version info', async () => {
    const res = await request(app).get('/api/version');

    expect(res.statusCode).toBe(200);
    expect(res.body.version).toBeDefined();
  });

  it('should return environment field', async () => {
    const res = await request(app).get('/api/version');

    expect(res.body.environment).toBeDefined();
  });

  it('should return commit field', async () => {
    const res = await request(app).get('/api/version');

    expect(res.body.commit).toBeDefined();
  });

  it('should return buildDate field', async () => {
    const res = await request(app).get('/api/version');

    expect(res.body.buildDate).toBeDefined();
  });
});