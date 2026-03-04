'use strict';

const request = require('supertest');
const { app, server } = require('../src/index');

// Close the server after all tests complete to avoid open handle warnings
afterAll((done) => {
  server.close(done);
});

// ─── GET / ────────────────────────────────────────────────────────────────────
describe('GET /', () => {
  it('should return 200 with a success message', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('message');
    expect(res.body.message).toMatch(/Running Successfully/);
  });

  it('should return a version field', async () => {
    const res = await request(app).get('/');
    expect(res.body).toHaveProperty('version');
  });

  it('should return a timestamp field', async () => {
    const res = await request(app).get('/');
    expect(res.body).toHaveProperty('timestamp');
  });
});

// ─── GET /health ──────────────────────────────────────────────────────────────
describe('GET /health', () => {
  it('should return 200 with status healthy', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('healthy');
  });

  it('should include uptime in the response', async () => {
    const res = await request(app).get('/health');
    expect(res.body).toHaveProperty('uptime');
    expect(typeof res.body.uptime).toBe('number');
  });
});

// ─── GET /info ────────────────────────────────────────────────────────────────
describe('GET /info', () => {
  it('should return 200 with app info', async () => {
    const res = await request(app).get('/info');
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('app');
    expect(res.body).toHaveProperty('node_version');
    expect(res.body).toHaveProperty('memory');
  });
});

// ─── 404 handler ─────────────────────────────────────────────────────────────
describe('Unknown routes', () => {
  it('should return 404 for an unknown route', async () => {
    const res = await request(app).get('/this-route-does-not-exist');
    expect(res.statusCode).toBe(404);
    expect(res.body).toHaveProperty('error', 'Route not found');
  });
});
