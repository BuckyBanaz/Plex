// src/types/multer-s3.d.ts
declare namespace Express {
  namespace Multer {
    interface File {
      location?: string; // added by multer-s3
      key?: string;
      bucket?: string;
    }
  }
}
