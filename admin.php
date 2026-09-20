<?php
session_start();
require __DIR__ . '/config.php';
$file = __DIR__ . '/data.json';
$msg = '';

function e($v){ return htmlspecialchars((string)$v, ENT_QUOTES, 'UTF-8'); }
function load($f){ return json_decode(file_get_contents($f), true); }
function save($f, $d){ file_put_contents($f, json_encode($d, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES), LOCK_EX); }

// ছবি আপলোড: সফল হলে ফাইলের নাম ফেরত দেয়
function upload($field){
  if (empty($_FILES[$field]['name']) || $_FILES[$field]['error'] !== UPLOAD_ERR_OK) return '';
  $f = $_FILES[$field];
  if ($f['size'] > 5*1024*1024) return '';
  $info = @getimagesize($f['tmp_name']);
  $ext = ['image/jpeg'=>'jpg','image/png'=>'png','image/webp'=>'webp'][$info['mime'] ?? ''] ?? '';
  if (!$ext) return '';
  $name = bin2hex(random_bytes(8)) . '.' . $ext;
  return move_uploaded_file($f['tmp_name'], __DIR__ . '/uploads/' . $name) ? $name : '';
}
function removeFile($name){ if ($name) @unlink(__DIR__ . '/uploads/' . basename($name)); }

// লগইন / লগআউট
if (isset($_GET['logout'])) { session_destroy(); header('Location: admin.php'); exit; }
if (isset($_POST['login'])) {
  if (hash_equals(ADMIN_PASSWORD, $_POST['password'] ?? '')) { $_SESSION['ok'] = true; session_regenerate_id(true); $_SESSION['csrf'] = bin2hex(random_bytes(16)); header('Location: admin.php'); exit; }
  $msg = 'পাসওয়ার্ড ভুল হয়েছে।';
}
$in = !empty($_SESSION['ok']);

if ($in && $_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action'])) {
  if (!hash_equals($_SESSION['csrf'], $_POST['csrf'] ?? '')) die('Invalid request');
  $data = load($file);
  switch ($_POST['action']) {
    case 'settings':
      foreach (['name','tagline','about_title','about_text','phone','address','hours','facebook','instagram','whatsapp'] as $k)
        $data['settings'][$k] = trim($_POST[$k] ?? '');
      if ($n = upload('hero_image')) { removeFile($data['settings']['hero_image']); $data['settings']['hero_image'] = $n; }
      $msg = 'সেটিংস সেভ হয়েছে ✅'; break;
    case 'add_dish':
      $name = trim($_POST['name'] ?? '');
      if ($name === '') { $msg = 'খাবারের নাম লিখুন।'; break; }
      $ids = array_column($data['dishes'], 'id');
      $data['dishes'][] = ['id' => ($ids ? max($ids) : 0) + 1, 'name' => $name, 'price' => (int)($_POST['price'] ?? 0), 'image' => upload('image')];
      $msg = 'নতুন খাবার যোগ হয়েছে ✅'; break;
    case 'edit_dish':
      foreach ($data['dishes'] as &$d) if ($d['id'] == (int)$_POST['id']) {
        $d['name'] = trim($_POST['name']); $d['price'] = (int)$_POST['price'];
        if ($n = upload('image')) { removeFile($d['image']); $d['image'] = $n; }
      } unset($d);
      $msg = 'খাবার আপডেট হয়েছে ✅'; break;
    case 'del_dish':
      foreach ($data['dishes'] as $i => $d) if ($d['id'] == (int)$_POST['id']) { removeFile($d['image']); unset($data['dishes'][$i]); }
      $data['dishes'] = array_values($data['dishes']);
      $msg = 'খাবার মুছে ফেলা হয়েছে।'; break;
    case 'add_gallery':
      if ($n = upload('image')) { $data['gallery'][] = ['image' => $n]; $msg = 'ছবি যোগ হয়েছে ✅'; }
      else $msg = 'ছবি আপলোড হয়নি (JPG/PNG/WEBP, সর্বোচ্চ 5MB)।';
      break;
    case 'del_gallery':
      foreach ($data['gallery'] as $i => $g) if ($g['image'] === $_POST['image']) { removeFile($g['image']); unset($data['gallery'][$i]); }
      $data['gallery'] = array_values($data['gallery']);
      $msg = 'ছবি মুছে ফেলা হয়েছে।'; break;
  }
  save($file, $data);
}
$data = $in ? load($file) : [];
$tab = $_GET['tab'] ?? 'dishes';
?>
<!DOCTYPE html>
<html lang="bn"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Admin Panel</title>
<style>
*{box-sizing:border-box}body{font-family:system-ui,sans-serif;background:#f4f1ec;margin:0;color:#222}
.top{background:#141110;color:#fff;padding:14px 20px;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:10px}
.top a{color:#e9a544;margin-left:14px}
.box{max-width:900px;margin:22px auto;padding:0 16px}
.tabs{display:flex;gap:8px;margin-bottom:16px;flex-wrap:wrap}
.tabs a{padding:10px 18px;background:#fff;border-radius:8px;text-decoration:none;color:#222;border:1px solid #ddd}
.tabs a.on{background:#d18b2f;color:#fff;border-color:#d18b2f}
.card{background:#fff;border-radius:10px;padding:18px;margin-bottom:14px;border:1px solid #e5ded2}
label{display:block;font-size:.85rem;font-weight:600;margin:10px 0 4px}
input[type=text],input[type=number],input[type=password],textarea{width:100%;padding:10px;border:1px solid #ccc;border-radius:6px;font:inherit}
button{background:#d18b2f;color:#fff;border:0;padding:10px 20px;border-radius:6px;font-weight:600;cursor:pointer;margin-top:12px}
button.red{background:#b3332b}
.msg{background:#e7f5e6;border:1px solid #9bd196;padding:10px 14px;border-radius:8px;margin-bottom:14px}
.row{display:flex;gap:14px;align-items:center;flex-wrap:wrap}
.row img,.thumb{width:80px;height:60px;object-fit:cover;border-radius:6px;background:#ddd}
.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(150px,1fr));gap:12px}
.grid img{width:100%;height:110px;object-fit:cover;border-radius:8px}
details summary{cursor:pointer;color:#d18b2f;font-weight:600}
</style></head><body>

<?php if (!$in): ?>
  <div class="box" style="max-width:380px;margin-top:80px">
    <div class="card"><h2>Admin Login</h2>
      <?php if ($msg): ?><div class="msg" style="background:#fde8e6;border-color:#e6a19b"><?= e($msg) ?></div><?php endif; ?>
      <form method="post"><label>পাসওয়ার্ড</label><input type="password" name="password" autofocus required>
      <button name="login" value="1">লগইন</button></form>
    </div>
  </div>
<?php else: $csrf = $_SESSION['csrf']; ?>
  <div class="top"><b>🍽️ <?= e($data['settings']['name']) ?> — Admin</b>
    <span><a href="index.php" target="_blank">সাইট দেখুন</a><a href="?logout=1">লগআউট</a></span></div>
  <div class="box">
    <div class="tabs">
      <a href="?tab=dishes" class="<?= $tab==='dishes'?'on':'' ?>">খাবারের মেনু</a>
      <a href="?tab=gallery" class="<?= $tab==='gallery'?'on':'' ?>">গ্যালারি</a>
      <a href="?tab=settings" class="<?= $tab==='settings'?'on':'' ?>">সাইট সেটিংস</a>
    </div>
    <?php if ($msg): ?><div class="msg"><?= e($msg) ?></div><?php endif; ?>

    <?php if ($tab === 'dishes'): ?>
      <div class="card"><h3>নতুন খাবার যোগ করুন</h3>
        <form method="post" enctype="multipart/form-data">
          <input type="hidden" name="csrf" value="<?= $csrf ?>"><input type="hidden" name="action" value="add_dish">
          <label>খাবারের নাম</label><input type="text" name="name" required>
          <label>দাম (৳)</label><input type="number" name="price" min="0" required>
          <label>ছবি (JPG/PNG/WEBP)</label><input type="file" name="image" accept="image/*">
          <button>যোগ করুন</button>
        </form></div>
      <?php foreach ($data['dishes'] as $d): ?>
        <div class="card"><div class="row">
          <?php if ($d['image']): ?><img src="uploads/<?= e($d['image']) ?>" alt=""><?php else: ?><div class="thumb"></div><?php endif; ?>
          <div style="flex:1"><b><?= e($d['name']) ?></b><br>৳ <?= e($d['price']) ?></div>
          <form method="post" onsubmit="return confirm('মুছে ফেলবেন?')">
            <input type="hidden" name="csrf" value="<?= $csrf ?>"><input type="hidden" name="action" value="del_dish"><input type="hidden" name="id" value="<?= $d['id'] ?>">
            <button class="red" style="margin:0">মুছুন</button></form>
        </div>
        <details style="margin-top:10px"><summary>এডিট করুন</summary>
          <form method="post" enctype="multipart/form-data">
            <input type="hidden" name="csrf" value="<?= $csrf ?>"><input type="hidden" name="action" value="edit_dish"><input type="hidden" name="id" value="<?= $d['id'] ?>">
            <label>নাম</label><input type="text" name="name" value="<?= e($d['name']) ?>" required>
            <label>দাম (৳)</label><input type="number" name="price" value="<?= e($d['price']) ?>" required>
            <label>নতুন ছবি (না দিলে আগেরটাই থাকবে)</label><input type="file" name="image" accept="image/*">
            <button>সেভ করুন</button></form></details></div>
      <?php endforeach; ?>

    <?php elseif ($tab === 'gallery'): ?>
      <div class="card"><h3>গ্যালারিতে ছবি যোগ করুন</h3>
        <form method="post" enctype="multipart/form-data">
          <input type="hidden" name="csrf" value="<?= $csrf ?>"><input type="hidden" name="action" value="add_gallery">
          <input type="file" name="image" accept="image/*" required><button>আপলোড</button></form></div>
      <div class="card"><div class="grid">
        <?php foreach ($data['gallery'] as $g): ?>
          <form method="post" onsubmit="return confirm('মুছে ফেলবেন?')">
            <img src="uploads/<?= e($g['image']) ?>" alt="">
            <input type="hidden" name="csrf" value="<?= $csrf ?>"><input type="hidden" name="action" value="del_gallery"><input type="hidden" name="image" value="<?= e($g['image']) ?>">
            <button class="red" style="width:100%;padding:6px">মুছুন</button></form>
        <?php endforeach; if (!$data['gallery']) echo '<p>এখনো কোনো ছবি নেই।</p>'; ?>
      </div></div>

    <?php else: $s = $data['settings']; ?>
      <div class="card"><form method="post" enctype="multipart/form-data">
        <input type="hidden" name="csrf" value="<?= $csrf ?>"><input type="hidden" name="action" value="settings">
        <label>রেস্টুরেন্টের নাম</label><input type="text" name="name" value="<?= e($s['name']) ?>">
        <label>ট্যাগলাইন (প্রথম পাতার লেখা)</label><textarea name="tagline" rows="2"><?= e($s['tagline']) ?></textarea>
        <label>About শিরোনাম</label><input type="text" name="about_title" value="<?= e($s['about_title']) ?>">
        <label>About লেখা</label><textarea name="about_text" rows="4"><?= e($s['about_text']) ?></textarea>
        <label>ফোন নম্বর</label><input type="text" name="phone" value="<?= e($s['phone']) ?>">
        <label>WhatsApp নম্বর (দেশের কোড সহ, যেমন 8801712345678)</label><input type="text" name="whatsapp" value="<?= e($s['whatsapp']) ?>">
        <label>ঠিকানা</label><input type="text" name="address" value="<?= e($s['address']) ?>">
        <label>খোলা থাকার সময়</label><input type="text" name="hours" value="<?= e($s['hours']) ?>">
        <label>Facebook লিংক</label><input type="text" name="facebook" value="<?= e($s['facebook']) ?>">
        <label>Instagram লিংক</label><input type="text" name="instagram" value="<?= e($s['instagram']) ?>">
        <label>প্রথম পাতার বড় ছবি (Hero)</label><input type="file" name="hero_image" accept="image/*">
        <button>সেভ করুন</button></form></div>
    <?php endif; ?>
  </div>
<?php endif; ?>
</body></html>
