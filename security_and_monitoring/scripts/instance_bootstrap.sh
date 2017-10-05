#! /bin/bash

META_DATA_URL="http://169.254.169.254/latest/meta-data/"
ATTRIBUTES="public-hostname instance-id"
INDEX=/var/www/html/index.html

yum install httpd -y
chkconfig httpd on

echo "<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="author" content="Martin Bean" />
    <title>DevOps ED AWS</title>
    <link rel="stylesheet" href="css/bootstrap.min.css" />
    <style>
        html, body {
            height: 100%;
        }
        footer {
            color: #666;
            background: #222;
            padding: 17px 0 18px 0;
            border-top: 1px solid #000;
        }
        footer a {
            color: #999;
        }
        footer a:hover {
            color: #efefef;
        }
        .wrapper {
            min-height: 100%;
            height: auto !important;
            height: 100%;
            margin: 0 auto -63px;
        }
        .push {
            height: 63px;
        }
        /* not required for sticky footer; just pushes hero down a bit */
        .wrapper > .container {
            padding-top: 60px;
        }
    </style>
  </head>
  <body>
    <div class="wrapper">
      <div class="container">
        <header class="hero-unit">
          <h1>DevOps ED AWS EC2 Instance:</h1>
          <p>--instance-id--</p>
          <p>--public-hostname--</p>
        </header>
      </div>
      <div class="push"><!--//--></div>
    </div>
    <footer>
      <div class="container">
        <p>Demo page for webinar</p>
      </div>
    </footer>
  </body>
</html>" >> $INDEX

for id in $ATTRIBUTES;do
  value=$(curl "$META_DATA_URL/$id")
  sed -i "s@--$id--@$value@" $INDEX
done

service httpd start
