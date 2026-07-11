-- Signature help que NO tapa el texto que escribes.
--
-- Problema: noice.nvim muestra el signature help en un popup pegado al cursor,
-- que al escribir dentro de paréntesis (ej. Foo(...)) se coloca ENCIMA de la
-- línea que tecleas → no ves lo que escribes hasta moverte.
--
-- Fix: apagar el signature de noice y usar el de blink.cmp en modo COMPACTO
-- (solo la línea de la firma, sin la documentación que lo agranda). blink lo
-- coloca en una línea adyacente al cursor, no encima, y al ser 1 línea tapa
-- mucho menos. Se mantiene el auto-signature; solo cambia dónde/cómo aparece.
--
-- Global (blink/noice no se pueden scopear por lenguaje de forma limpia), pero
-- el problema y el beneficio son iguales en todos los lenguajes.

return {
  -- 1) Apagar el signature help de noice (el que tapaba el texto)
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        signature = { enabled = false },
      },
    },
  },

  -- 2) Usar el signature de blink.cmp, compacto (sin documentación)
  {
    "saghen/blink.cmp",
    opts = {
      signature = {
        enabled = true,
        window = {
          border = "rounded",
          show_documentation = false, -- solo la firma → ventana de 1 línea, tapa menos
          -- Preferir mostrar el signature ARRIBA del cursor (norte); si no cabe,
          -- abajo. Así rara vez cubre la línea que estás escribiendo.
          direction_priority = { "n", "s" },
        },
      },
    },
  },
}
