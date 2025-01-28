# rwk_filehandler

A really simple HTML5 file handler and plugin.



## Simple Interface

### Drag and Drop

As an Alpine package, we'll only need to pull the package down via npm
(or include it at the &lt;script&gt; tag in the top of the page)
and decorate the HTML with the tags needed to turn on our file handler.
The second method is detailed below:

```
&lt;script defer src="/path/to/alpine.js"&gt;&lt;/script&gt;
&lt;script src="/path/to/filehandler.js"&gt;&lt;/script&gt;
```

Start by dropping the `x-filedrop` decorator into your 
HTML somewhere.  This will turn your div into a "drop zone" for whatever
media you plan to accept in your app. 
Here we've used a `&lt;div&gt;` decorated with a 
`drophandler` class.
(In our case, a &lt;div&gt; with the class `drophandler`.)

```
&lt;div class="filehandler"&gt;
&lt;div class="drophandler" x-filedrop&gt; 
&lt;div&gt;Drop your images here.&lt;/div&gt;
&lt;/div&gt;
&lt;div&gt;
&lt;div x-show='$filedata?.url'&gt;
&lt;img :src="$filedata?.url"&gt;
&lt;/div&gt;
&lt;/div&gt;
&lt;/div&gt;
```


### Explicit Old-School Button
			
Like our drag and drop example, it's pretty easy to get this going as well.

```
&lt;div class="filehandler"&gt;
  &lt;div class="drophandler" x-filesink&gt; 
    &lt;div&gt;Drop your images here.&lt;/div&gt;
  &lt;/div&gt;
  &lt;div&gt;
    &lt;div x-show='$filedata?.url'&gt;
      &lt;img :src="$filedata?.url"&gt;
    &lt;/div&gt;
  &lt;/div&gt;
&lt;/div&gt;
```

Drop the `x-filesink` decorator into your HTML somewhere.  
(In our case, a &lt;div&gt; with the class `drophandler`.)



## Installation


For simple drop-in, do something like this:

```
&lt;script defer src="/path/to/alpine.js"&gt;&lt;/script&gt;
&lt;script src="/path/to/filehandler.js"&gt;&lt;/script&gt;
```


## Questions

If you are having some issues using this, send me a message below and I might be able to help out.


