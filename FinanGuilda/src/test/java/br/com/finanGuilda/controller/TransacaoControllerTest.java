package br.com.finanGuilda.controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@DirtiesContext(classMode = DirtiesContext.ClassMode.BEFORE_EACH_TEST_METHOD)
class TransacaoControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void deveListarTransacoesIniciais() throws Exception {
        mockMvc.perform(get("/api/transacoes"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].descricao").value("Recompensa de Missão"));
    }

    @Test
    void deveObterResumoFinanceiro() throws Exception {
        mockMvc.perform(get("/api/transacoes/resumo"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalReceitas").value(250.0))
                .andExpect(jsonPath("$.totalDespesas").value(45.0))
                .andExpect(jsonPath("$.saldo").value(205.0));
    }

    @Test
    void deveCadastrarNovaTransacaoComSucesso() throws Exception {
        String json = """
                {
                    "descricao": "Escudo de Aço",
                    "valor": 120.0,
                    "tipo": "despesa",
                    "categoria": "Equipamentos"
                }
                """;

        mockMvc.perform(post("/api/transacoes")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").isNumber())
                .andExpect(jsonPath("$.descricao").value("Escudo de Aço"))
                .andExpect(jsonPath("$.tipo").value("DESPESA"))
                .andExpect(jsonPath("$.categoria").value("Equipamentos"));
    }

    @Test
    void deveDeletarTransacaoExistente() throws Exception {
        mockMvc.perform(delete("/api/transacoes/1"))
                .andExpect(status().isNoContent());
    }

    @Test
    void deveRetornarNotFoundAoDeletarTransacaoInexistente() throws Exception {
        mockMvc.perform(delete("/api/transacoes/999"))
                .andExpect(status().isNotFound());
    }

    @Test
    void deveRejeitarTransacaoComDescricaoCurta() throws Exception {
        String json = """
                {
                    "descricao": "Oi",
                    "valor": 50.0,
                    "tipo": "RECEITA"
                }
                """;

        mockMvc.perform(post("/api/transacoes")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json))
                .andExpect(status().isBadRequest());
    }

    @Test
    void deveRejeitarTransacaoComValorInvalido() throws Exception {
        String json = """
                {
                    "descricao": "Venda de item",
                    "valor": -10.0,
                    "tipo": "RECEITA"
                }
                """;

        mockMvc.perform(post("/api/transacoes")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json))
                .andExpect(status().isBadRequest());
    }

    @Test
    void deveRejeitarTransacaoComTipoInvalido() throws Exception {
        String json = """
                {
                    "descricao": "Doação",
                    "valor": 100.0,
                    "tipo": "OUTRO"
                }
                """;

        mockMvc.perform(post("/api/transacoes")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json))
                .andExpect(status().isBadRequest());
    }
}
