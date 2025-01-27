/*
 * filehandler.js
 * =================
 *
 * A deadly simple file handler. 
 *
 * Usage 
 * -------
 *
 *  ```
 *  <!-- Within your HTML page include a reference to this code -->
 *  <script src="/path/to/hg-filehandler.js"></script>
 *
 *  <!-- 
 *  Within your Alpine app, mark a div or input field using x-filedrop or x-filesink respectively.  
 *  NOTE: Both can be used at the same time, the resulting file sink will process from both
 *  -->
 *  <div x-data="app">
 *    ...
 *    <div style="width: 200px; height: 200px; display: inline-block;" x-filedrop></div>
 *    <input type="file" style="width: 200px; height: 20px; display: inline-block;" x-filesink>
 *    ...
 *  </div> 
 *
 *  <!-- 
 *  Finally, mark a div, img, video or other type of element with $filedata?.url
 *  NOTE: The following assumes that you want to upload and preview an image.  
 *  Also notice that we're binding the src property with a colon.
 *  -->
 *  <img :src="$filedata?.url">
 *  ```
 *
 * Caveats
 * -------
 * Currently only allows for ONE FILE to be uploaded somewhere on a page.
 *
 * Modifying this will be a matter of turning filedata into an array and making
 * some other function to push and pop from said array.
 *
 * TODO
 * ----
 * Limit the scope of each instance of x-filehandler so that more than one 
 * handler can be on a page.
 *
 */
document.addEventListener( "alpine:init", () => {

  // Define the store content here
  Alpine.store( 'filedata', { 

    // Unsure if this is needed or not
    content: null,

    // Returns a hash of something so that we can identify elements later...
    // NOTE: This will only be necessary for multiple instances of this component
    hash: (x) => digest( "SHA-1", x ),
    sink: { pre: false, post: false },
    drop: { pre: false, post: false }

  } )


  // Should just return the contents in base64 (unsure how many other formats should be supported)
  Alpine.magic( 'filedata', (el) => {
    return Alpine.store( 'filedata' ).content
  })


  // When a user uses the classic file upload, we SHOULD be able to see the contents
  Alpine.directive( 'filesink', ( el, { values, modifiers, expression }, { evaluate } ) => {
    console.log( 'Directive "filesink" is registered"' )
		console.log( el )

    if ( modifiers && modifiers.length ) {
      const name = modifiers[0]
      if ( name == 'pre' )
        Alpine.store( 'filedata' ).sink.pre = expression
      else if ( name == 'post' ) {
        Alpine.store( 'filedata' ).sink.post = expression
      }
      return
    }

    el.addEventListener( "change", async (ev) => {
      
      // References are a bit different with traditional file upload
      const meta = el.files[ 0 ]
      const extract = (str) => str.substr( str.indexOf( "," ) + 1 )
      const filereader = new FileReader()
      filereader.readAsDataURL( meta )

      // Extract just the content out of the blob
      filereader.addEventListener( "load", (et) => {

        // Clean any other file input
        const store = Alpine.store( 'filedata' )

        // If a pre hook is defined, run that here
        if ( store.sink.pre ) {
          evaluate( store.sink.pre )
        }
        
        // Extract the content 
        const content = extract( filereader.result )
        //const object = {
        Alpine.store( 'filedata' ).content = {
          bsize: meta.size,
          mimetype: meta.type,
          name: meta.name,
          content: content,
          size: content.length,
          url: filereader.result,
          data: filereader.result
        }

        // If a post hook is defined, run that here
        if ( store.sink.post ) {
          evaluate( store.sink.post )
        }
      })
    })
  })


  // This handles drag and drop
  Alpine.directive( 'filedrop', ( el, { values, modifiers, expression }, { evaluate } ) => {
    console.log( 'Directive "filedrop" is registered"' )
		console.log( el )

    // Register pre & post handlers here
    if ( modifiers && modifiers.length ) {
      const name = modifiers[0]
      if ( name == 'pre' )
        Alpine.store( 'filedata' ).drop.pre = expression
      else if ( name == 'post' ) {
        Alpine.store( 'filedata' ).drop.post = expression
      }
      return
    }

    // Assume the current element is what we want to turn into a file handler
    el.addEventListener( "dragenter", (ev) => ( ev.stopPropagation, ev.preventDefault() ) )
    el.addEventListener( "dragover", (ev) => ( ev.stopPropagation, ev.preventDefault() ) )
    el.addEventListener( "drop", (ev) => {
      
      // Stop any default events
      ev.stopPropagation, ev.preventDefault()

      // Set up any references
      const meta = ev.dataTransfer.files[ 0 ]
      const filereader = new FileReader()
      const extract = (str) => str.substr( str.indexOf( "," ) + 1 )
      const store = Alpine.store( 'filedata' )
      filereader.readAsDataURL( meta )

      // Handle the actual load
      filereader.addEventListener( "load", (et) => {

        // If a pre hook is defined, run that here
        if ( store.drop.pre ) {
          evaluate( store.drop.pre )
        }

        // Extract just the content out of the blob
        const content = extract( filereader.result )

        // Then package an object that can be easily returned and dealt with
        Alpine.store( 'filedata' ).content = {
        //const object = {
          bsize: meta.size,
          mimetype: meta.type,
          name: meta.name,
          content: content,
          size: content.length,
          dataUrl: filereader.result,
          url: filereader.result,
          data: filereader.result
        }

        // Likewise for a post hook...
        if ( store.drop.post ) {
          evaluate( store.drop.post )
        }

      })
    })
  })
})
