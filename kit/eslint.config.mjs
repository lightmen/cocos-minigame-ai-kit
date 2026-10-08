import js from '@eslint/js';
import tseslint from 'typescript-eslint';

/**
 * 把宪法里最容易被无意破坏的几条变成报错。
 * 原则 3 → core/ 禁止 import 'cc'、禁止不确定性来源
 * 原则 4 → platform/ 之外禁止 wx / window / document / localStorage
 * 原则 5 → 禁止 find() 路径字符串查找节点
 * 原则 6 → net/generated/ 跳过检查
 *
 * 依赖：eslint、@eslint/js、typescript-eslint。
 * 已有 eslint.config.mjs 的工程不要整文件覆盖，把下面三段 rules 并进去。
 */
export default tseslint.config(
    {
        ignores: [
            'build/**',
            'library/**',
            'temp/**',
            'local/**',
            'profiles/**',
            'node_modules/**',
            'assets/scripts/net/generated/**',
        ],
    },

    js.configs.recommended,
    ...tseslint.configs.recommended,

    {
        files: ['assets/scripts/**/*.ts'],
        rules: {
            '@typescript-eslint/no-explicit-any': 'error',
            '@typescript-eslint/ban-ts-comment': 'error',
        },
    },
    {
        files: ['assets/scripts/**/*.ts'],
        ignores: ['assets/scripts/platform/**'],
        rules: {
            'no-restricted-globals': [
                'error',
                {
                    name: 'wx',
                    message:
                        '宪法原则 4：微信 API 必须收口到 assets/scripts/platform/，否则编辑器里跑不起来。',
                },
                {
                    name: 'window',
                    message: '宪法原则 4：平台差异请封装在 platform/ 层。',
                },
                {
                    name: 'document',
                    message: '宪法原则 4：小游戏没有 DOM，平台差异请封装在 platform/ 层。',
                },
                {
                    name: 'localStorage',
                    message: '宪法原则 4：存储请走 platform/storage。',
                },
            ],
            'no-restricted-syntax': [
                'error',
                {
                    selector: "CallExpression[callee.name='find'][arguments.0.type='Literal']",
                    message:
                        '宪法原则 5：禁止用路径字符串查找节点，改用 @property 在编辑器里拖引用。',
                },
            ],
        },
    },
    {
        files: ['assets/scripts/core/**/*.ts'],
        rules: {
            'no-restricted-imports': [
                'error',
                {
                    paths: [
                        {
                            name: 'cc',
                            message:
                                "宪法原则 3：core/ 禁止 import 'cc'。需要向量运算请在 core/math/ 自己实现。",
                        },
                    ],
                    patterns: [
                        {
                            group: ['../game/*', '../ui/*', '../platform/*', '../net/*'],
                            message: 'core/ 不能反向依赖上层。数据由上层传入。',
                        },
                    ],
                },
            ],
            'no-restricted-properties': [
                'error',
                {
                    object: 'Math',
                    property: 'random',
                    message: '确定性要求：core/ 禁止 Math.random()，请使用注入的种子随机。',
                },
                {
                    object: 'Date',
                    property: 'now',
                    message: '确定性要求：core/ 禁止读取真实时间，时间应由外部以参数传入。',
                },
                {
                    object: 'performance',
                    property: 'now',
                    message: '确定性要求：core/ 禁止读取真实时间，时间应由外部以参数传入。',
                },
            ],
        },
    },
    {
        files: ['tests/**/*.ts'],
        rules: {
            '@typescript-eslint/no-explicit-any': 'off',
        },
    },
);
