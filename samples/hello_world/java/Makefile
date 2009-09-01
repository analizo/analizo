hello_world: Main.class HelloWorld.class
	@echo '#!/bin/sh' > $@
	@echo "java Main" >> $@
	@chmod +x $@

%.class: %.java
	javac $<

clean:
	rm -f *.class hello_world
