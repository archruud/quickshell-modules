#!/usr/bin/env python3
"""Real Python file + __main__ guard to avoid NPU multiprocessing re-import."""
import multiprocessing as mp


def main():
    import openvino as ov
    print('OPENVINO_VERSION=' + str(getattr(ov, '__version__', 'unknown')), flush=True)
    core = ov.Core()
    devices = list(core.available_devices)
    print('OPENVINO_DEVICES=' + ','.join(devices), flush=True)
    for expected in ('CPU', 'GPU', 'NPU'):
        print(f'OPENVINO_{expected}={int(expected in devices)}', flush=True)
    for device in devices:
        try:
            full_name = core.get_property(device, 'FULL_DEVICE_NAME')
        except Exception as exc:
            full_name = f'unavailable: {exc!r}'
        print(f'OPENVINO_NAME_{device}={full_name}', flush=True)


if __name__ == '__main__':
    mp.freeze_support()
    main()
