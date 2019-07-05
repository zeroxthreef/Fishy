<html>
	<title>Template system test</title>
	<body>
		<h1>Something smells fishy</h1>
		looks like you have a message from the site init function:<br><br>
		<b><i>[@localworld]</i></b>
		<br><br>
		<h2>and something from another file:</h2>
		[@include embedded.html] <!-- note that [[@include "hey.html"] also works (when unescaped) -->
		<br><br>
		[[@include nothing.html]. The tag was escaped and now you can see it.
		<br><br>
		<a href="place">go to another location</a>
	</body>
</html>