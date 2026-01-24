import multer from "multer";
import multerS3 from "multer-s3";
import { s3, S3_BUCKET_NAME } from "../config/aws.config";

export const upload = multer({
  storage: multerS3({
    s3: s3,
    bucket: S3_BUCKET_NAME,
    contentType: multerS3.AUTO_CONTENT_TYPE,
    acl: "public-read",
    key: (req: any, file, cb) => {  // 👈 add `req: any`
      const userId = req.body?.userId || "general"; // use optional chaining
      const fileName = `shipments/${userId}/${Date.now()}_${file.originalname}`;
      cb(null, fileName);
    },
  }),
  fileFilter: (req: any, file, cb) => { // 👈 add `req: any`
    if (file.mimetype.startsWith("image/") || file.mimetype.startsWith("video/")) {
      cb(null, true);
    } else {
      cb(new Error("Only images and videos are allowed!"));
    }
  },
});
