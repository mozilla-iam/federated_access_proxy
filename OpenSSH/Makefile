CA_FILE		:= server_ca
CA_SIG_EXPIRE	:= +64w
CA_COMMENT	:= Certificate Authority
CA_CN		:= python.testrp.security.allizom.org

generateca: $(CA_FILE)
$(CA_FILE):
	ssh-keygen -f "$(CA_FILE)" -C "$(CA_COMMENT)" -N ''

clean:
	-rm *pub
	-rm *key
	-rm $(CA_FILE)

.PHONY: clean
