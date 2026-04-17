import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';

import healthRouter from './routes/health.js';
import usersRouter from './routes/users.js';
import versionRouter from './routes/version.js';

const app = express();

// --- Middleware ---
app.use(helmet());                          // security headers
app.use(cors());                            // cross-origin requests
app.use(morgan('dev'));                     // request logging
app.use(express.json());                    // parse JSON bodies

// --- Routes ---
app.use('/health',       healthRouter);
app.use('/api/users',    usersRouter);
app.use('/api/version',  versionRouter);

// --- 404 Handler ---
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// --- Global Error Handler ---
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

export default app;