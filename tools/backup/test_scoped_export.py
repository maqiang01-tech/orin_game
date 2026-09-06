"""Scoped backup excludes runtime state and preserves unrelated archived bytes."""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

class ScopedExportTests(unittest.TestCase):
    def test_scope_preserves_history_excludes_bridge_and_detects_missing_source(self):
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp);downloads=root/'downloads';downloads.mkdir()
            state=root/'.codex/coordination/receipt.json';state.parent.mkdir(parents=True)
            state.write_bytes(b'{"decision":"PASS"}\n')
            runtime=root/'.codex/bridge/credential-placeholder.txt';runtime.parent.mkdir(parents=True)
            runtime.write_text('must never be exported')
            dst=root/'export';dst.mkdir();(dst/'history.txt').write_bytes(b'old')
            old={'path':'history.txt','source':str(root/'unrelated-missing.txt'),
                 'sha256':hashlib.sha256(b'old').hexdigest(),'bytes':3}
            prior_exclusion={'source':str(root/'old-cache.db'),'reason':'database_cache_or_sensitive_filename'}
            (dst/'BACKUP_MANIFEST.json').write_text(json.dumps({'files':[old],'excluded_files':[prior_exclusion]}))
            cmd=[shutil.which('pwsh'),' -NoProfile'.strip(),'-File',str(Path(__file__).with_name('export-workflow.ps1')),
                 '-ProjectRoot',str(root),'-Destination',str(dst),'-SkillsRoot',str(root/'skills'),
                 '-DownloadsRoot',str(downloads),'-ScopePaths','.codex']
            result=subprocess.run(cmd,capture_output=True)
            self.assertEqual(result.returncode,0,result.stderr.decode(errors='replace'))
            manifest=json.loads((dst/'BACKUP_MANIFEST.json').read_text(encoding='utf-8'))
            self.assertEqual({x['path'] for x in manifest['files']},{'history.txt','project_snapshot/.codex/coordination/receipt.json'})
            self.assertEqual((dst/'history.txt').read_bytes(),b'old')
            self.assertEqual(manifest['excluded_files'],[prior_exclusion])
            self.assertFalse((dst/'project_snapshot/.codex/bridge').exists())
            state.unlink()
            result=subprocess.run(cmd,capture_output=True)
            self.assertNotEqual(result.returncode,0)
            self.assertIn(b'Previously exported path disappeared',result.stderr)

    def test_bridge_scope_is_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp);(root/'.codex/bridge').mkdir(parents=True)
            cmd=[shutil.which('pwsh'),'-NoProfile','-File',str(Path(__file__).with_name('export-workflow.ps1')),
                 '-ProjectRoot',str(root),'-Destination',str(root/'export'),'-SkillsRoot',str(root),
                 '-DownloadsRoot',str(root),'-ScopePaths','.codex/bridge']
            result=subprocess.run(cmd,capture_output=True)
            self.assertNotEqual(result.returncode,0)
            self.assertIn(b'not exportable scope',result.stderr)

if __name__=='__main__':unittest.main(verbosity=2)
