SERVER_CA_FILE		:= server_ca
SERVER_CA_SIG_EXPIRE	:= +64w
CLIENT_CA_FILE		:= client_ca
CLIENT_CA_SIG_EXPIRE	:= +1h
CA_COMMENT		:= Certificate Authority
CA_CN			:= localhost
CA_ALG			:= ecdsa


all:
	@echo "Make sure you know what you are doing before using this Makefile."

generateclientca: $(CLIENT_CA_FILE)
$(CLIENT_CA_FILE):
	ssh-keygen -f "$(CLIENT_CA_FILE)" -t $(CA_ALG) -C "$(CA_COMMENT)"
	@echo "Protect $(CLIENT_CA_FILE) with the upmost level of care. It is extremely sensitive"


generateserverca: $(SERVER_CA_FILE)
$(SERVER_CA_FILE):
	ssh-keygen -f "$(SERVER_CA_FILE)" -t $(CA_ALG) -C "$(CA_COMMENT)"
	@echo "Protect $(SERVER_CA_FILE) with the upmost level of care. It is extremely sensitive"

clean:
	-rm *pub
	-rm *key
	-rm $(CA_FILE)

.PHONY: clean all
