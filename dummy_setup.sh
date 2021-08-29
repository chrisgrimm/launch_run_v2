(rm -rf vepi || echo "")
(rm -rf venv || echo "")
(rm -rf Roms || echo "")
git clone git@github.com:chrisgrimm/vepi.git
python3.8 -m venv venv
source venv/bin/activate
pip install -r vepi/requirements.txt
pip install --upgrade wand ray[default] ray[tune]
pip uninstall jax jaxlib
pip install --upgrade "jax[cuda111]" -f https://storage.googleapis.com/jax-releases/jax_releases.html
wandb login 204bba2f92205170a0a1b3503365f454fa38dfc8
export PYTHONPATH=/app/vepi
export XLA_PYTHON_CLIENT_PREALLOCATE=false
export RAY_BACKEND_LOG_LEVEL=error
wget http://www.atarimania.com/roms/Roms.rar
unp Roms.rar
python -m atari_py.import_roms Roms
