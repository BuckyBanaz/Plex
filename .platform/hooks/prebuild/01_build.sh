#!/bin/bash
# ==============================
# Elastic Beanstalk prebuild hook
# ==============================



npm install @types/express @types/body-parser @types/pg @types/jsonwebtoken @types/bcrypt @types/swagger-jsdoc @types/swagger-ui-express 
npm install --include=dev 
npm run build 
