import { withMermaid } from 'vitepress-plugin-mermaid';
import fs from 'fs';
import { defineConfig } from 'vitepress';

// https://vitepress.dev/reference/site-config
// Uncomment this to enable mermaid inside your site when this is solved: https://github.com/mermaid-js/mermaid/issues/4320
export default withMermaid({
  vue: {
    template: {
      compilerOptions: {
        // treat all tags with a dash as custom elements
        isCustomElement: (tag) => tag.includes("-"),
      },
    },
  },
  vite: {
    optimizeDeps: {
      include: ['mermaid', 'dayjs', '@braintree/sanitize-url'],
    },
  },
  base: "/service-providers-zome",
  title: "Service Providers Zome",
  description: "Service Providers zome for holochain apps",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config

    sidebar: [
      {
        text: "Setup",
        link: "/setup.md",
      },
      {
        text: "API Reference",
        items: [
          {
            text: "Integrity Zome",
            link: "/backend/doc/service_providers_integrity/index.html",
            target: "_blank",
          },
          {
            text: "Coordinator Zome",
            link: "/backend/doc/service_providers/index.html",
            target: "_blank",
          },
          {
            text: "Frontend",
            items: [
              {
                text: "ServiceProvidersStore",
                link: "/service-providers-store.md",
              },
              {
                text: "Elements",
                items: fs.readdirSync("./elements").filter(file => file.endsWith('.md')).map(el =>
                ({
                  text: el.split('.md')[0],
                  link: `/elements/${el}`,
                }),
                ),
              },
            ],
          },
        ],
      },
    ],

    socialLinks: [
      {
        icon: "github",
        link: "https://github.com/darksoil-studio/service-providers-zome",
      },
    ],
    search: {
      provider: 'local'
    }
  },
  head: [
    [
      'script',
      {},
      // Synchronize the vitepress dark/light theme with the shoelace mode
      `
  function syncTheme() {
      const isDark = document.documentElement.classList.contains('dark');
      const isShoelaceDark = document.body.classList.contains('sl-theme-dark');
      if (isDark && !isShoelaceDark) {
	      document.body.classList = "sl-theme-dark";
	    }
      if (!isDark && isShoelaceDark) {
      	document.body.classList = "";
      }
  }
  const attrObserver = new MutationObserver((mutations) => {
    mutations.forEach(mu => {
      if (mu.type !== "attributes" && mu.attributeName !== "class") return;
      syncTheme();
    });
  });
  attrObserver.observe(document.documentElement, {attributes: true});
  syncTheme();
        `
    ]
  ],
});
