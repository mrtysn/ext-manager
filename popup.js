const api = globalThis.browser ?? globalThis.chrome;

const listEl = document.getElementById("list");
const searchEl = document.getElementById("search");

let rows = [];

async function load() {
    const all = await api.management.getAll();
    rows = all
        .filter((ext) => ext.type === "extension" && ext.id !== api.runtime.id)
        .sort((a, b) => a.name.localeCompare(b.name));
    render();
}

function render() {
    const q = searchEl.value.trim().toLowerCase();
    const filtered = q
        ? rows.filter((r) => r.name.toLowerCase().includes(q))
        : rows;
    listEl.replaceChildren(...filtered.map(toRow));
}

function toRow(ext) {
    const li = document.createElement("li");
    li.className = ext.enabled ? "" : "disabled";

    const icon = document.createElement("span");
    icon.className = "icon";

    const initial = document.createElement("span");
    initial.className = "initial";
    initial.textContent = (ext.name.trim().charAt(0) || "?").toUpperCase();
    icon.appendChild(initial);

    resolveIconUrl(ext).then((url) => {
        if (!url) return;
        const img = document.createElement("img");
        img.alt = "";
        img.onload = () => initial.remove();
        img.onerror = () => img.remove();
        img.src = url;
        icon.appendChild(img);
    });

    const name = document.createElement("span");
    name.className = "name";
    name.textContent = ext.name;
    name.title = ext.name;

    const toggle = document.createElement("input");
    toggle.type = "checkbox";
    toggle.className = "toggle";
    toggle.checked = ext.enabled;
    toggle.addEventListener("change", async () => {
        try {
            await api.management.setEnabled(ext.id, toggle.checked);
            ext.enabled = toggle.checked;
            li.classList.toggle("disabled", !ext.enabled);
        } catch (err) {
            toggle.checked = ext.enabled;
            console.error(err);
        }
    });

    li.append(icon, name, toggle);
    return li;
}

async function resolveIconUrl(ext) {
    const key = `amoIcon:${ext.id}`;
    const cached = await api.storage.local.get(key);
    if (key in cached) return cached[key];

    const url = await fetchAMOIcon(ext.id);
    await api.storage.local.set({ [key]: url });
    return url;
}

async function fetchAMOIcon(id) {
    try {
        const res = await fetch(
            `https://addons.mozilla.org/api/v5/addons/addon/${encodeURIComponent(id)}/`,
        );
        if (!res.ok) return null;
        const data = await res.json();
        return data.icon_url ?? null;
    } catch {
        return null;
    }
}

searchEl.addEventListener("input", render);
load();
