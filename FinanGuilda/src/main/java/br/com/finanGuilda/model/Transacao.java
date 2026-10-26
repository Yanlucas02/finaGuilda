package br.com.finanGuilda.model;

import br.com.finanGuilda.exception.TransacaoInvalidaException;

public record Transacao(
        int id,
        String descricao,
        double valor,
        String tipo,      // "RECEITA" ou "DESPESA"
        String categoria
) {
    public Transacao {
        if (descricao == null || descricao.trim().length() < 3) {
            throw new TransacaoInvalidaException("A descrição precisa ter no mínimo 3 caracteres.");
        }
        if (valor <= 0) {
            throw new TransacaoInvalidaException("O valor monetário deve ser estritamente maior que zero.");
        }
        if (tipo == null || (!tipo.equalsIgnoreCase("RECEITA") && !tipo.equalsIgnoreCase("DESPESA"))) {
            throw new TransacaoInvalidaException("O tipo deve ser RECEITA ou DESPESA.");
        }
        descricao = descricao.trim();
        if (categoria == null || categoria.trim().isEmpty()) {
            categoria = "Geral";
        } else {
            categoria = categoria.trim();
        }
        tipo = tipo.toUpperCase();
    }
}
