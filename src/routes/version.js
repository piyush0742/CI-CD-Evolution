import { Router } from 'express';

const router = Router();

router.get('/', (req, res) => {
  res.status(200).json({
    version:     process.env.APP_VERSION  || '1.0.0',
    environment: process.env.NODE_ENV     || 'development',
    commit:      process.env.GIT_COMMIT   || 'local',    // injected by CI
    buildDate:   process.env.BUILD_DATE   || 'local',    // injected by CI
  });
});

export default router;