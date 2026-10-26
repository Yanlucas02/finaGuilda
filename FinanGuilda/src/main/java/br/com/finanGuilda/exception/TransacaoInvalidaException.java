package br.com.finanGuilda.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.BAD_REQUEST)
public class TransacaoInvalidaException extends RuntimeException {
    public TransacaoInvalidaException(String mensagem) {
        super(mensagem);
    }
}
