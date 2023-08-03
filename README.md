# manga2pdf

This script is used to convert a manga book, which is a bunch of image files like JPG, downloaded by Hakuneko program (from mangasee123.com).

## How-to

Suppose the book is downloaded into `/home/myuser/Downloads` directory and has the following structure:

```
MyBook
  |__ Chapter 1
      |__ 01.jpg
      |__ 02.jpg
      |__ 03.jpg
  |__ Chapter 2
      |__ 01.jpg
      |__ 02.jpg
```

Then, open Terminal and run:
```
$ ./manga2pdf.sh "/home/myuser/Downloads/MyBook"
```

### Converting specific chapters
```
$ ./manga2pdf.sh "~/Downloads/MyBook" -from 1 -to 5
```
This is helpful if the book has more than 100 chapters.
