String.prototype.replaceAt=function(index, char ) { return this.substr(0, index) + char + this.substr(index+char.length); }
String.prototype.replace2At=function(index, char1, char2 ) { return this.substr(0, index) + char1 + char2 + this.substr(index+char1.length+char2.length); }

function scram29c3run() { 
  var elem = document.getElementById( 'header-29c3-scramble' );
  if ( elem ) { var scram = new scram29c3( elem ); scram.run(); }
  elem = document.getElementById( 'header-29c3-scramble2' );
  if ( elem ) { var scram = new scram29c3( elem ); scram.run(); }
}

scram29c3 = function(elem) {
  if((typeof document.getElementById == "undefined") || (typeof elem.innerHTML == "undefined")) { this.running = true; return; }
  this.element = elem;
  this.interval = 200;
  this.mode = 2; // 2 - begin, 1 forward, -1 backward, 0 change a break char every 5 seconds
  this.Text = this.element.innerHTML.replace( /\n/g, '' ).replace(/<([^<])*>/g, '').replace(/&gt;/g,'>').replace(/&lt;/g,'<').replace(/&amp;g/,'&');
  this.stack = Array();
  this.element.scram29c3 = this;
  this.running = false;
  this.enough = false;
}

scram29c3.prototype.setenough = function() { this.enough = true; }
scram29c3.prototype.run = function() {
  var breaks='/.-{}()[]<>|,;!?';
  var i, c, c0, c1;

  if(this.running) return;
  if(typeof this.Text == "undefined") { setTimeout("document.getElementById('" + this.element.id + "').scram29c3.run()", this.interval); return; }

  // Set an alert, so that on slow machines the animation won't take longer than 4 seconds
  if( this.mode == 2 ) {
    setTimeout("document.getElementById('" + this.element.id + "').scram29c3.setenough()", 2350 );
    this.mode = 1;
  }

  for( var a=0; a<3; ++a ) { // two chars per run
    if ( this.mode == 1 ) { // Running forward, i.e. making up new breaks

      // Find an exchangable break/alpha pair
      do {
        var foo = this.Text.length;
        i = Math.floor( Math.random( ) * ( this.Text.length - 1 ) );
        c0 = ( 1 + breaks.indexOf( this.Text.charAt(i  ) ) ) ? 1 : 0;
        c1 = ( 1 + breaks.indexOf( this.Text.charAt(i+1) ) ) ? 1 : 0;
      } while( c0 == c1 );

      // Remember what we exchanged where so we can always roll back
      this.stack.push(i);
      if( c0 ) {
        this.stack.push( this.Text.charAt(i) );
        this.Text = this.Text.replace2At(i,this.Text.charAt(i+1),breaks.charAt( Math.floor( Math.random( ) * breaks.length ) ) );
      } else {
        this.stack.push( this.Text.charAt(i+1) );
        this.Text = this.Text.replace2At(i,breaks.charAt( Math.floor( Math.random( ) * breaks.length ) ),this.Text.charAt(i) );
      }
   } else if( this.mode == -1 ) {
      c = this.stack.pop();
      i = this.stack.pop();
      if( 1 + breaks.indexOf( this.Text.charAt(i) ) ) {
        this.Text = this.Text.replace2At(i,this.Text.charAt(i+1),c);
      } else {
        this.Text = this.Text.replace2At(i,c,this.Text.charAt(i));
      }
    }
  }

  if( this.mode == 0 ) {
    // Restore char that has been swapped out last
    if( this.stack.length ) {
      c = this.stack.pop();
      i = this.stack.pop();
      this.Text = this.Text.replaceAt(i,c);
    }
    // Find an exchangable break character
    do {
      i = Math.floor( Math.random( ) * ( this.Text.length - 1 ) );
    } while( 0 == ( 1 + breaks.indexOf( this.Text.charAt(i) ) ) );
    this.stack.push(i);
    this.stack.push(this.Text.charAt(i));
    this.Text = this.Text.replaceAt(i,breaks.charAt( Math.floor( Math.random( ) * breaks.length ) ) );
  }

  // Escape HTML chars and insert zero width white spaces
  var textarray = this.Text.split('');
  for(i = 0;i< textarray.length; i++) {
    textarray[i] = textarray[i].replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }
  this.element.innerHTML = textarray.join('<wbr>');

  if( this.mode == 1 ) {
    this.interval-=10;
    if( this.interval<12 || this.enough ) {
      this.mode = -1;
    }
  } else if( this.mode == -1 ) {
    this.interval+=10;
    if( this.interval==200 ) {
      this.mode = 0;
      this.interval = 5000;
    }
  }

  setTimeout("document.getElementById('" + this.element.id + "').scram29c3.run()", this.interval);
}

if(window.addEventListener){ window.addEventListener('load',scram29c3run(),false); } else{ window.attachEvent('onload',scram29c3run()); }
