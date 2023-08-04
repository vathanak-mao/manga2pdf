# manga2pdf

This script is used to convert a manga book, which is a collection of image files like JPG, into PDF files (one per chapter). The book may be downloaded by [Hakuneko](https://hakuneko.download/) program.

## Prerequisites
This script uses the `convert` command from `ImageMagick` package. To install the package,
```
$ sudo apt install imagemagick-6.q16
```

## How-to

Suppose the book is downloaded into `/home/myuser/Downloads` directory and has the following structure:

```
MyBook
  |__ Chapter 1
  |  |__ 01.jpg
  |  |__ 02.jpg
  |  |__ 03.jpg
  |__ Chapter 2
     |__ 01.jpg
     |__ 02.jpg
     ...

```

Each page in a chapter is a JPG file. To merge and convert them into a single PDF file for each chapter, open Terminal and run:
```
$ ./manga2pdf.sh "/home/myuser/Downloads/___ Manga/MyBook"
```
The output:
```
MyBook
  |__ Chapter 1
  |  |__ 01.jpg
  |  |__ 02.jpg
  |  |__ 03.jpg
  |__ Chapter 2
  |  |__ 01.jpg
  |  |__ 02.jpg
  |   ...
  |__ Chapter1.pdf
  |__ Chapter2.pdf
```

### Limit the number of chapters
To create PDF files for chapter 1, 2, 3, 4, and 5:
```
$ ./manga2pdf.sh /home/myuser/Downloads/___\ Manga/MyBook -from 1 -to 5
```
### Merge the output chapters
To create PDF files for chapter 1, 2, 3, 4, and 5 and then merge them into a single PDF file:
```
$ ./manga2pdf.sh /home/myuser/Downloads/___\ Manga/MyBook -from 1 -to 5 --merge
```
The output is:
```
MyBook
  |__ Chapter 1
  |  |__ 01.jpg
  |  |__ 02.jpg
  |  |__ 03.jpg
  |__ Chapter 2
  |  |__ 01.jpg
  |  |__ 02.jpg
  |   ...
  |__ Chapter1.pdf
  |__ Chapter2.pdf
  |
  |__ Chapter1-2.pdf
```

