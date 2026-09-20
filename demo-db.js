/* ============================================================
   DEMO MODE — Supabase ছাড়াই সাইট + admin চালানোর জন্য
   config.js এ Supabase key না বসালে এটা নিজে থেকে চালু হয়।
   Data শুধু এই browser এ (localStorage) থাকে।
   Demo login:  email = admin@demo.com   password = demo123
   ============================================================ */
const DEMO = SUPABASE_URL.startsWith('YOUR');
const DEMO_EMAIL = 'admin@demo.com';
const DEMO_PASSWORD = 'demo123';

function createDemoClient() {
  const KEY = 'afghan_demo_db', AUTH = 'afghan_demo_auth';
  const seed = () => ({
    settings: [{
      id: 1, name: 'Afghan Restaurant',
      tagline: 'Delicious food, warm hospitality and a memorable experience — all in one place.',
      about_title: 'Good Food, Great Moments',
      about_text: 'Afghan Restaurant is a small and cozy place where we serve delicious and healthy food with the best quality ingredients. Our goal is to make every meal a memorable experience for our guests.',
      phone: '+880 1700-000000', address: 'Moulvibazar Sadar, Sylhet, Bangladesh', hours: '10:00 AM - 10:00 PM',
      facebook: '', instagram: '', whatsapp: '8801700000000', hero_image: '', logo: '', favicon: '', bkash_number: '01700000000'
    }],
    dishes: [['Afghan Beef Pulao', 250, 'Rice'], ['Chicken Korma', 220, 'Curry'], ['Afghan Chicken Pulao', 200, 'Rice'], ['Beef Karahi', 280, 'Curry'], ['Chicken Roast', 180, 'Grill']]
      .map((d, i) => ({ id: i + 1, name: d[0], price: d[1], category: d[2], image: '', created_at: new Date().toISOString() })),
    gallery: [], orders: [],
    posts: [{ id: 1, title: 'Welcome to our new website', image: '', created_at: new Date().toISOString(),
      body: 'We are happy to share our new website with you.\n\nNow you can see our menu, follow our news and order online, all in one place.' }]
  });
  const read = () => {
    let d; try { d = JSON.parse(localStorage.getItem(KEY)) || seed(); } catch (e) { d = seed(); }
    if (!d.posts) d.posts = seed().posts;
    (d.dishes || []).forEach(x => { if (!('days' in x)) x.days = ''; if (!('is_new' in x)) x.is_new = false; });
    (d.dishes || []).forEach(x => { if (!('category' in x)) x.category = ''; });
    (d.settings || []).forEach(x => { if (!('is_open' in x)) x.is_open = true; if (!('announcement' in x)) x.announcement = ''; if (!('map_query' in x)) x.map_query = ''; if (!('bkash_number' in x)) x.bkash_number = ''; });
    return d;
  };
  const write = d => localStorage.setItem(KEY, JSON.stringify(d));
  const copy = x => JSON.parse(JSON.stringify(x));

  function from(table) {
    const q = { op: 'select', filters: [], order: null, limit: null, single: false, payload: null };
    const b = {
      select() { return b; },
      insert(p) { q.op = 'insert'; q.payload = p; return b; },
      update(p) { q.op = 'update'; q.payload = p; return b; },
      delete() { q.op = 'delete'; return b; },
      eq(c, v) { q.filters.push([c, v]); return b; },
      order(c, o) { q.order = [c, o && o.ascending === false ? -1 : 1]; return b; },
      limit(n) { q.limit = n; return b; },
      single() { q.single = true; return b; },
      then(res, rej) { return run().then(res, rej); }
    };
    async function run() {
      try {
        const d = read(), rows = d[table] || (d[table] = []);
        const match = r => q.filters.every(([c, v]) => r[c] == v);
        if (q.op === 'select') {
          let out = rows.filter(match);
          if (q.order) out.sort((a, z) => (a[q.order[0]] > z[q.order[0]] ? 1 : -1) * q.order[1]);
          if (q.limit) out = out.slice(0, q.limit);
          if (q.single) return out.length ? { data: copy(out[0]), error: null } : { data: null, error: { message: 'not found' } };
          return { data: copy(out), error: null };
        }
        let touched = [];
        if (q.op === 'insert') {
          const dup = table === 'orders' && [].concat(q.payload).some(p => p.trx_id && rows.some(r => String(r.trx_id || '').toUpperCase() === String(p.trx_id).toUpperCase()));
          if (dup) return { data: null, error: { code: '23505', message: 'duplicate key value violates unique constraint "orders_trx_unique"' } };
          [].concat(q.payload).forEach(p => {
            const id = rows.reduce((m, r) => Math.max(m, r.id || 0), 0) + 1;
            const row = Object.assign({ id, created_at: new Date().toISOString() }, table === 'orders' ? { status: 'new', payment_method: 'cod', paid: false } : {}, p);
            rows.push(row); touched.push(row);
          });
        } else if (q.op === 'update') {
          rows.forEach(r => { if (match(r)) { Object.assign(r, q.payload); touched.push(r); } });
        } else if (q.op === 'delete') {
          touched = rows.filter(match);
          d[table] = rows.filter(r => !match(r));
        }
        write(d);
        return { data: copy(touched), error: null };
      } catch (e) {
        return { data: null, error: { message: 'Demo এ জায়গা শেষ — কম বা ছোট ছবি ব্যবহার করুন' } };
      }
    }
    return b;
  }

  // ছবি ছোট করে data URL বানায় (localStorage এ কম জায়গা লাগে)
  function shrink(blob) {
    return new Promise((res, rej) => {
      const url = URL.createObjectURL(blob), img = new Image();
      img.onload = () => {
        const png = blob.type === 'image/png', max = png ? 400 : 700;
        const r = Math.min(1, max / Math.max(img.width, img.height));
        const c = document.createElement('canvas');
        c.width = Math.round(img.width * r); c.height = Math.round(img.height * r);
        c.getContext('2d').drawImage(img, 0, 0, c.width, c.height);
        URL.revokeObjectURL(url);
        res(c.toDataURL(png ? 'image/png' : 'image/jpeg', 0.7));
      };
      img.onerror = () => { URL.revokeObjectURL(url); rej(new Error('bad image')); };
      img.src = url;
    });
  }
  const files = {};
  const storage = {
    from() {
      return {
        async upload(path, body) {
          try { files[path] = await shrink(body); return { error: null }; }
          catch (e) { return { error: { message: 'ছবিটি পড়া যাচ্ছে না (SVG নয়, JPG/PNG দিন)' } }; }
        },
        getPublicUrl(path) { return { data: { publicUrl: files[path] || '' } }; },
        async remove() { return { error: null }; }
      };
    }
  };

  const auth = {
    async getSession() { return { data: { session: sessionStorage.getItem(AUTH) ? { demo: true } : null } }; },
    async signInWithPassword({ email, password }) {
      if (password === DEMO_PASSWORD && String(email).trim().toLowerCase() === DEMO_EMAIL) {
        sessionStorage.setItem(AUTH, '1'); return { data: {}, error: null };
      }
      return { data: {}, error: { message: 'wrong' } };
    },
    async signOut() { sessionStorage.removeItem(AUTH); return { error: null }; }
  };

  return { from, storage, auth };
}
