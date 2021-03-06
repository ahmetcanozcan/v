import os
import term

fn test_all() {
	$if windows {
		return
	}
	mut total_errors := 0
	vexe := os.getenv('VEXE')
	vroot := os.dir(vexe)
	dir := os.join_path(vroot,'vlib/v/tests/inout')
	files := os.ls(dir) or {
		panic(err)
	}
	println(files)
	tests := files.filter(it.ends_with('.vv'))
	if tests.len == 0 {
		println('no compiler tests found')
		assert false
	}
	for test in tests {
		path := os.join_path(dir,test)
		print(test + ' ')
		program := path.replace('.vv', '.v')
		os.cp(path, program) or {
			panic(err)
		}
		os.rm('exe')
		x := os.exec('$vexe -o exe -cflags "-w" -cg $program') or {
			panic(err)
		}
		// os.rm(program)
		res := os.exec('./exe') or {
			println('nope')
			panic(err)
		}
		// println('============')
		// println(res.output)
		// println('============')
		mut expected := os.read_file(program.replace('.v', '') + '.out') or {
			panic(err)
		}
		expected = expected.trim_space()
		found := res.output.trim_space()
		if expected != found {
			println(term.red('FAIL'))
			println(x.output.limit(30))
			println('============')
			println('expected:')
			println(expected)
			println('\nfound:')
			println(found)
			println('============')
			total_errors++
		}
		else {
			println(term.green('OK'))
		}
	}
	assert total_errors == 0
}
