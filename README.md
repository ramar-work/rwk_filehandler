# rwk_filehandler

A really simple HTML5 file handler and plugin.



## Simple Interface

### Drag and Drop

As an Alpine package, we'll only need to pull the package down via npm
(or include it at the <script> tag in the top of the page)
and decorate the HTML with the tags needed to turn on our file handler.
The second method is detailed below:

```
<script defer src="/path/to/alpine.js"></script>
<script src="/path/to/filehandler.js"></script>
```

Start by dropping the `x-filedrop` decorator into your 
HTML somewhere.  This will turn your div into a "drop zone" for whatever
media you plan to accept in your app. 
Here we've used a `<div>` decorated with a 
`drophandler` class.
(In our case, a <div> with the class `drophandler`.)

```
<div class="filehandler">
<div class="drophandler" x-filedrop> 
<div>Drop your images here.</div>
</div>
<div>
<div x-show='$filedata?.url'>
<img :src="$filedata?.url">
</div>
</div>
</div>
```


### Explicit Old-School Button
			
Like our drag and drop example, it's pretty easy to get this going as well.

```
<div class="filehandler">
  <div class="drophandler" x-filesink> 
    <div>Drop your images here.</div>
  </div>
  <div>
    <div x-show='$filedata?.url'>
      <img :src="$filedata?.url">
    </div>
  </div>
</div>
```

Drop the `x-filesink` decorator into your HTML somewhere.  
(In our case, a <div> with the class `drophandler`.)



## Installation


For simple drop-in, do something like this:

```
<script defer src="/path/to/alpine.js"></script>
<script src="/path/to/filehandler.js"></script>
```


## Questions

If you are having some issues using this, send me a message below and I might be able to help out.


