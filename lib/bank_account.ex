defmodule Ofex.BankAccount do
  alias Ofex.Transaction
  import Ofex.Helpers
  import SweetXml

  def create(ofx_data) do
    account = xpath(ofx_data, ~x"STMTTRNRS",
                request_id: ~x"./TRNUID/text()"s,
                status_code: ~x"./STATUS/CODE/text()"s,
                status_severity: ~x"./STATUS/SEVERITY/text()"s,
                currency: ~x"./STMTRS/CURDEF/text()"s,
                routing_number: ~x"./STMTRS/BANKACCTFROM/BANKID/text()"s,
                account_number: ~x"./STMTRS/BANKACCTFROM/ACCTID/text()"s,
                type: ~x"./STMTRS/BANKACCTFROM/ACCTTYPE/text()"s,
                transactions: ~x"./STMTRS/BANKTRANLIST/STMTTRN"l |> transform_by(&parse_transactions(&1)),
                balance: ~x"./STMTRS/LEDGERBAL/BALAMT/text()"f,
                positive_balance: ~x"./STMTRS/LEDGERBAL/BALAMT/text()"s |> transform_by(&string_to_float/1),
                balance_date: ~x"./STMTRS/LEDGERBAL/DTASOF/text()"s,
              )
    {:bank_account, account}
  end

  defp parse_transactions(ofx_transactions) do
    Enum.map(ofx_transactions, &Transaction.create(&1))
  end
end