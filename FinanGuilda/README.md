# FinanGuilda API ⚔️💰

API REST de Gestão Financeira desenvolvida em Java com Spring Boot, projetada para integração com aplicações front-end e mobile (como Flutter).

---

## 🚀 Tecnologias

- **Java 17 / 21**
- **Spring Boot 3.3.4**
- **Maven** (Wrapper incluído)
- **JUnit 5 / MockMvc**

---

## 📌 Endpoints da API

Base URL: `http://localhost:8080/api/transacoes`

| Método | Endpoint | Descrição | Status Sucesso | Status Erro |
|---|---|---|---|---|
| `GET` | `/api/transacoes` | Lista todas as transações cadastradas | `200 OK` | - |
| `GET` | `/api/transacoes/resumo` | Retorna total de receitas, despesas e saldo | `200 OK` | - |
| `POST` | `/api/transacoes` | Cadastra uma nova transação | `201 CREATED` | `400 BAD REQUEST` |
| `DELETE` | `/api/transacoes/{id}` | Remove uma transação pelo ID | `204 NO CONTENT` | `404 NOT FOUND` |

---

### Exemplo de Payload para Cadastro (`POST /api/transacoes`):

```json
{
  "descricao": "Recompensa de Missão",
  "valor": 350.00,
  "tipo": "RECEITA",
  "categoria": "Serviços"
}
```

#### Regras de Validação:
- `descricao`: Obrigatória e com no mínimo 3 caracteres.
- `valor`: Estritamente maior que zero (`> 0`).
- `tipo`: Deve ser `"RECEITA"` ou `"DESPESA"` (não diferencia maiúsculas/minúsculas).
- `categoria`: Opcional (valor padrão: `"Geral"`).

---

## ⚙️ Como Executar

### Pré-requisitos
- JDK 17 ou superior instalado.

### Executando a Aplicação
No Windows (PowerShell):
```powershell
.\mvnw.cmd spring-boot:run
```

No Linux/macOS:
```bash
./mvnw spring-boot:run
```

A API estará disponível em: `http://localhost:8080`

### Executando os Testes Automatizados
```powershell
.\mvnw.cmd test
```
