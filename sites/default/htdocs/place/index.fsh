<html>
	<body>
		[[@escape [[@echo "hey " 2 " " .]]
		<br><br>
		[@echo-if-exact 1 [@echo "hey " 2 " " .]]
		<br><br>
		[@var-set test 4]
		<br><br>
		[@var-get test]
		<hr></hr>
		<h2>loop test</h2>
		<br>
		[@var-set loop_begin ""]
		<h2>turing completeness</h2>
		<br>
		
	</body>
</html>