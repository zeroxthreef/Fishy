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
		<h2>printing a grid</h2>
		<br>
		[@var-set temp 4]
		TODO make the beginning of tags get echoed twice so they dont get run too early
		[@echo-if-space 1 "[@echo-space \"[@math + \"] [var-get temp] [@echo-space \"3]\"]"]
	</body>
</html>