import request from 'supertest';
import app from '../src/app.js';

describe('GET /health', () => {
  it('should return status ok with 200', async () => {
    const res = await request(app).get('/health');

    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('ok');
  });

  it('should return uptime as a number', async () => {
    const res = await request(app).get('/health');

    expect(typeof res.body.uptime).toBe('number');
  });

  it('should return a valid timestamp', async () => {
    const res = await request(app).get('/health');

    expect(res.body.timestamp).toBeDefined();
    expect(new Date(res.body.timestamp).toString()).not.toBe('Invalid Date');
  });

  it('should return the environment', async () => {
    const res = await request(app).get('/health');

    expect(res.body.environment).toBeDefined();
  });
});